<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class PrimerIngresoController extends Controller
{
    public function cambiarPassword(Request $request)
    {
        $request->validate([
            'password'              => 'required|min:8|confirmed',
            'password_confirmation' => 'required',
        ]);

        $user = $request->user();

        // La nueva contraseña no puede ser igual al DNI
        if ($request->password === $user->dni) {
            return response()->json([
                'message' => 'La contraseña no puede ser igual a tu DNI.'
            ], 422);
        }

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Contraseña actualizada correctamente.'
        ]);
    }

    public function registrarContacto(Request $request)
    {
        $request->validate([
            'email'    => 'required|email|unique:users,email,' . $request->user()->id,
            'telefono' => 'required|string|max:15',
        ]);

        $request->user()->update([
            'email'    => $request->email,
            'telefono' => $request->telefono,
        ]);

        return response()->json([
            'message' => 'Datos de contacto registrados correctamente.'
        ]);
    }
}