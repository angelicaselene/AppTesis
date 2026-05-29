<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ValuacionPuesto;
use App\Models\EscalaSalarial;
use Illuminate\Http\Request;

class DetalleEscalaController extends Controller
{
    public function index()
    {
        $anio = date('Y');

        // Distribución por banda salarial
        $escala = EscalaSalarial::where('anio', $anio)
            ->whereNotNull('junior')
            ->get();

        $bandas = ['MASTER' => 0, 'SENIOR' => 0, 'JUNIOR' => 0];
        $puntajesPorBanda = ['MASTER' => [], 'SENIOR' => [], 'JUNIOR' => []];

        $users = User::with(['contrato.cargo'])->whereHas('contrato')->get();

        foreach ($users as $user) {
            if (!$user->contrato || !$user->contrato->cargo) continue;
            $cargo = strtoupper(trim($user->contrato->cargo->nombre));
            $valuacion = ValuacionPuesto::where('puesto', $cargo)->first();
            if (!$valuacion) continue;

            $puntos = $valuacion->formacion_profesional +
                $valuacion->investigacion + $valuacion->experiencia +
                $valuacion->excelencia_servicio + $valuacion->capacidad_resolutiva +
                $valuacion->emprendimiento + $valuacion->innovacion +
                $valuacion->competencia_digital + $valuacion->mental +
                $valuacion->emocional + $valuacion->fisico +
                $valuacion->cumplimiento_metas + $valuacion->responsabilidades_financieras +
                $valuacion->prestacion_servicios + $valuacion->confidencialidad +
                $valuacion->manejo_materiales + $valuacion->manejo_personas +
                $valuacion->riesgo_ambiental + $valuacion->riesgo_psicologico;

            if ($puntos >= 700) {
                $bandas['MASTER']++;
                $puntajesPorBanda['MASTER'][] = $puntos;
            } elseif ($puntos >= 400) {
                $bandas['SENIOR']++;
                $puntajesPorBanda['SENIOR'][] = $puntos;
            } else {
                $bandas['JUNIOR']++;
                $puntajesPorBanda['JUNIOR'][] = $puntos;
            }
        }

        $scorePromedio = [];
        foreach ($puntajesPorBanda as $banda => $puntos) {
            $scorePromedio[$banda] = count($puntos) > 0
                ? round(array_sum($puntos) / count($puntos), 1)
                : 0;
        }

        // Índice de equidad y brecha
        $totalUsuarios = array_sum($bandas);
        $indiceEquidad = $totalUsuarios > 0
            ? round((($bandas['SENIOR'] + $bandas['MASTER']) / $totalUsuarios) * 100, 1)
            : 0;

        $escalaMax = EscalaSalarial::where('anio', $anio)->max('master');
        $escalaMin = EscalaSalarial::where('anio', $anio)->whereNotNull('junior')->min('junior');
        $brechaSalarial = $escalaMin > 0
            ? round((($escalaMax - $escalaMin) / $escalaMax) * 100, 1)
            : 0;

        return response()->json([
            'indice_equidad'   => $indiceEquidad,
            'brecha_salarial'  => $brechaSalarial,
            'bandas'           => $bandas,
            'score_promedio'   => $scorePromedio,
            'pesos_factores'   => [
                ['factor' => 'COMPETENCIAS', 'porcentaje' => 50],
                ['factor' => 'ESFUERZO', 'porcentaje' => 15],
                ['factor' => 'RESPONSABILIDAD', 'porcentaje' => 30],
                ['factor' => 'CONDICIONES TRAB.', 'porcentaje' => 5],
            ],
        ]);
    }
}