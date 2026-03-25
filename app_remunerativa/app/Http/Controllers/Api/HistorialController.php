<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\HistorialSalarial;
use Illuminate\Http\Request;

class HistorialController extends Controller
{
    public function index(Request $request)
    {
        $historial = HistorialSalarial::where('user_id', $request->user()->id)
            ->orderBy('fecha', 'asc')
            ->get()
            ->map(function($h) {
                return [
                    'cargo'        => $h->cargo,
                    'remuneracion' => $h->remuneracion,
                    'fecha'        => $h->fecha,
                ];
            });

        return response()->json($historial);
    }
}