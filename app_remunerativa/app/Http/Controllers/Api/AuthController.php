<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'dni'      => 'required',
            'password' => 'required',
        ]);

        $user = User::with('rol')->where('dni', $request->dni)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciales incorrectas'
            ], 401);
        }

        // Revocar tokens anteriores y crear uno nuevo
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login correcto',
            'token'   => $token,
            'user'    => [
                'id'      => $user->id,
                'nombres' => $user->nombres,
                'dni'     => $user->dni,
                'rol'     => $user->rol->nombre,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'Sesión cerrada correctamente'
        ]);
    }
}
