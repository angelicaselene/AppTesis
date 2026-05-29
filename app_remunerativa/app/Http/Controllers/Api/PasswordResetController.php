<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\OtpMail;
use App\Models\PasswordResetOtp;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class PasswordResetController extends Controller
{
    // Paso 1: Usuario ingresa su email → enviar OTP
    public function sendOtp(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'No encontramos una cuenta con ese correo.'
            ], 404);
        }

        // Eliminar OTPs anteriores de este usuario
        PasswordResetOtp::where('user_id', $user->id)->delete();

        // Generar código de 6 dígitos
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        PasswordResetOtp::create([
            'user_id'    => $user->id,
            'otp'        => $otp,
            'expires_at' => now()->addMinutes(10),
            'used'       => false,
        ]);

        Mail::to($user->email)->send(new OtpMail($otp, $user->nombres));

        return response()->json([
            'message' => 'Código enviado a tu correo.'
        ]);
    }

    // Paso 2: Verificar el OTP
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp'   => 'required|string|size:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'Correo no válido.'], 404);
        }

        $otpRecord = PasswordResetOtp::where('user_id', $user->id)
            ->where('otp', $request->otp)
            ->where('used', false)
            ->first();

        if (!$otpRecord || !$otpRecord->isValid()) {
            return response()->json([
                'message' => 'El código es inválido o ha expirado.'
            ], 422);
        }

        return response()->json([
            'message' => 'Código válido.',
            'user_id' => $user->id,
        ]);
    }

    // Paso 3: Cambiar la contraseña
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email'                 => 'required|email',
            'otp'                   => 'required|string|size:6',
            'password'              => 'required|min:8|confirmed',
            'password_confirmation' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'Correo no válido.'], 404);
        }

        $otpRecord = PasswordResetOtp::where('user_id', $user->id)
            ->where('otp', $request->otp)
            ->where('used', false)
            ->first();

        if (!$otpRecord || !$otpRecord->isValid()) {
            return response()->json([
                'message' => 'El código es inválido o ha expirado.'
            ], 422);
        }

        // Marcar OTP como usado y actualizar contraseña
        $otpRecord->update(['used' => true]);
        $user->update(['password' => Hash::make($request->password)]);

        return response()->json([
            'message' => 'Contraseña actualizada correctamente.'
        ]);
    }
}