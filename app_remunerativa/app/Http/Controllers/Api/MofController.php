<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClasificacionPuesto;
use Illuminate\Http\Request;

class MofController extends Controller
{
    /**
     * Listar puestos con filtros opcionales: categoria, nivel, buscar (puesto)
     */
    public function index(Request $request)
    {
        $query = ClasificacionPuesto::query();

        if ($request->filled('categoria')) {
            $query->whereRaw('UPPER(categoria) = ?', [strtoupper($request->categoria)]);
        }

        if ($request->filled('nivel')) {
            $query->where('nivel', $request->nivel);
        }

        if ($request->filled('buscar')) {
            $query->where('puesto', 'like', '%' . $request->buscar . '%');
        }

        $puestos = $query->orderBy('categoria')->orderBy('perfil')->orderBy('nivel')->get();

        return response()->json($puestos);
    }

    /**
     * Listar categorías únicas (para el dropdown de filtro)
     */
    public function categorias()
    {
        $categorias = ClasificacionPuesto::distinct()->pluck('categoria')->filter()->values();
        return response()->json($categorias);
    }
}
