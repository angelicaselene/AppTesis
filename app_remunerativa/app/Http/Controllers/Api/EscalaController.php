<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EscalaSalarial;
use Illuminate\Http\Request;

class EscalaController extends Controller
{
    public function anios()
    {
        $anios = EscalaSalarial::select('anio')
            ->distinct()
            ->orderBy('anio', 'desc')
            ->pluck('anio');

        return response()->json($anios);
    }

    public function index(Request $request)
    {
        $anio = $request->get('anio', '2025');
        $seccion = $request->get('seccion');

        $query = EscalaSalarial::where('anio', $anio)
            ->select('id', 'seccion', 'categoria', 'perfil', 'nivel', 'puesto', 'modalidad', 'valor', 'junior', 'senior', 'master');

        if ($seccion) {
            $query->where('seccion', $seccion);
        }

        $data = $query->orderBy('seccion')
            ->orderBy('categoria')
            ->orderBy('perfil')
            ->orderBy('nivel')
            ->get();

        return response()->json($data);
    }
}