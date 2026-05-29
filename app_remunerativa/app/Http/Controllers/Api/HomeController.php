<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ClasificacionPuesto;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function indicadores(Request $request)
    {
        $totalUsuarios = User::count();
        $totalPuestos  = ClasificacionPuesto::distinct('puesto')->count('puesto');

        return response()->json([
            'total_usuarios' => $totalUsuarios,
            'total_puestos'  => $totalPuestos,
        ]);
    }
}
