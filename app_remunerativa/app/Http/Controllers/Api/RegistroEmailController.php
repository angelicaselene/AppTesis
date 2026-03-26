<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class RegistroEmailController extends Controller
{
    public function registrar(Request $request)
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
            'message' => 'Correo y teléfono registrados correctamente.'
        ]);
    }
}