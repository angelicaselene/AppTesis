<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ClasificacionPuesto;
use App\Models\ValuacionPuesto;
use Illuminate\Http\Request;

class UsuariosController extends Controller
{
    public function index(Request $request)
    {
        $query = User::with(['contrato.cargo', 'contrato.departamento', 'rol']);

        if ($request->filled('nombre')) {
            $query->where('nombres', 'like', '%' . $request->nombre . '%');
        }

        if ($request->filled('categoria')) {
            $query->whereHas('contrato.cargo', function($q) use ($request) {
                $q->whereExists(function($sub) use ($request) {
                    $sub->from('clasificacion_puestos')
                        ->whereRaw('UPPER(TRIM(clasificacion_puestos.puesto)) = UPPER(TRIM(cargos.nombre))')
                        ->whereRaw('UPPER(categoria) = ?', [strtoupper($request->categoria)]);
                });
            });
        }

        if ($request->filled('puesto')) {
            $query->whereHas('contrato.cargo', function($q) use ($request) {
                $q->where('nombre', 'like', '%' . $request->puesto . '%');
            });
        }

        $usuarios = $query->paginate(20)->through(function($user) {
            $clasificacion = null;
            if ($user->contrato && $user->contrato->cargo) {
                $nombreCargo = strtoupper(trim($user->contrato->cargo->nombre));
                $clasificacion = ClasificacionPuesto::whereRaw('UPPER(TRIM(puesto)) = ?', [$nombreCargo])->first();
            }

            return [
                'id'            => $user->id,
                'nombres'       => $user->nombres,
                'dni'           => $user->dni,
                'email'         => $user->email,
                'sexo'          => $user->sexo,
                'telefono'      => $user->telefono,
                'fecha_nac'     => $user->fecha_nac,
                'cargo'         => $user->contrato->cargo->nombre ?? null,
                'departamento'  => $user->contrato->departamento->nombre ?? null,
                'tipo_contrato' => $user->contrato->tipo_contrato ?? null,
                'fecha_ingreso' => $user->contrato->fecha_ingreso ?? null,
                'remuneracion'  => $user->contrato->remuneracion ?? null,
                'clasificacion' => $clasificacion ? [
                    'categoria' => $clasificacion->categoria,
                    'perfil'    => $clasificacion->perfil,
                    'nivel'     => $clasificacion->nivel,
                    'puesto'    => $clasificacion->puesto,
                ] : null,
            ];
        });

        return response()->json($usuarios);
    }

    public function valuacion(Request $request, $id)
    {
        $user = User::with(['contrato.cargo'])->findOrFail($id);
        $cargo = strtoupper(trim($user->contrato->cargo->nombre ?? ''));

        $valuacion = ValuacionPuesto::where('puesto', $cargo)->first();

        if (!$valuacion) {
            return response()->json(['message' => 'Sin valuación para este puesto'], 404);
        }

        return response()->json($valuacion);
    }
}