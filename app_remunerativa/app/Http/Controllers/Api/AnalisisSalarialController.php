<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ValuacionPuesto;
use App\Models\ClasificacionPuesto;
use App\Models\EscalaSalarial;
use App\Models\Contrato;
use Illuminate\Http\Request;

class AnalisisSalarialController extends Controller
{
    public function index()
    {
        $users = User::with(['contrato.cargo', 'contrato.departamento'])
            ->whereHas('contrato')
            ->get();

        $dispersión = [];
        $masaPorCategoria = [];
        $totalMasa = 0;

        foreach ($users as $user) {
            if (!$user->contrato || !$user->contrato->cargo) continue;

            $cargo = strtoupper(trim($user->contrato->cargo->nombre));
            $remuneracion = floatval($user->contrato->remuneracion ?? 0);

            $valuacion = ValuacionPuesto::where('puesto', $cargo)->first();
            if (!$valuacion) continue;

            $puntos = $valuacion->formacion_profesional +
                $valuacion->investigacion +
                $valuacion->experiencia +
                $valuacion->excelencia_servicio +
                $valuacion->capacidad_resolutiva +
                $valuacion->emprendimiento +
                $valuacion->innovacion +
                $valuacion->competencia_digital +
                $valuacion->mental +
                $valuacion->emocional +
                $valuacion->fisico +
                $valuacion->cumplimiento_metas +
                $valuacion->responsabilidades_financieras +
                $valuacion->prestacion_servicios +
                $valuacion->confidencialidad +
                $valuacion->manejo_materiales +
                $valuacion->manejo_personas +
                $valuacion->riesgo_ambiental +
                $valuacion->riesgo_psicologico;

            $clasificacion = ClasificacionPuesto::whereRaw('UPPER(TRIM(puesto)) = ?', [$cargo])->first();
            $categoria = $clasificacion->categoria ?? 'Sin categoría';

            $dispersión[] = [
                'nombre'       => $user->nombres,
                'puntos'       => $puntos,
                'remuneracion' => $remuneracion,
                'categoria'    => $categoria,
            ];

            if (!isset($masaPorCategoria[$categoria])) {
                $masaPorCategoria[$categoria] = 0;
            }
            $masaPorCategoria[$categoria] += $remuneracion;
            $totalMasa += $remuneracion;
        }

        $masaConPorcentaje = [];
        foreach ($masaPorCategoria as $cat => $total) {
            $masaConPorcentaje[] = [
                'categoria'  => $cat,
                'total'      => round($total, 2),
                'porcentaje' => $totalMasa > 0 ? round(($total / $totalMasa) * 100, 1) : 0,
            ];
        }

        usort($masaConPorcentaje, fn($a, $b) => $b['porcentaje'] <=> $a['porcentaje']);

        return response()->json([
            'dispersion'    => $dispersión,
            'masa_salarial' => $masaConPorcentaje,
            'total_masa'    => round($totalMasa, 2),
        ]);
    }

    public function rangos()
    {
        $anio = date('Y');

        $costoActual = Contrato::sum('remuneracion');

        $escala = EscalaSalarial::where('anio', $anio)
            ->whereNotNull('junior')
            ->whereNotNull('master')
            ->selectRaw('
                MIN(junior) as junior_min,
                MAX(junior) as junior_max,
                MIN(senior) as senior_min,
                MAX(senior) as senior_max,
                MIN(master) as master_min,
                MAX(master) as master_max
            ')
            ->first();

        return response()->json([
            'costo_actual'        => round($costoActual, 2),
            'costo_propuesto'     => round($costoActual * 1.045, 2),
            'incremento_promedio' => 4.5,
            'rangos'              => $escala ? [
                'junior_min' => $escala->junior_min,
                'junior_max' => $escala->junior_max,
                'senior_min' => $escala->senior_min,
                'senior_max' => $escala->senior_max,
                'master_min' => $escala->master_min,
                'master_max' => $escala->master_max,
            ] : null,
        ]);
    }
}