<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClasificacionPuesto;
use App\Models\EscalaSalarial;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PerfilController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user()->load(['rol', 'contrato.cargo', 'contrato.departamento', 'contrato.grupoCalculo']);

        $clasificacion = null;
        if ($user->contrato && $user->contrato->cargo) {
            $nombreCargo = strtoupper(trim($user->contrato->cargo->nombre));
            $clasificacion = ClasificacionPuesto::whereRaw('UPPER(TRIM(puesto)) = ?', [$nombreCargo])->first();
        }

        return response()->json([
            'id'        => $user->id,
            'nombres'   => $user->nombres,
            'dni'       => $user->dni,
            'sexo'      => $user->sexo,
            'email'     => $user->email,
            'telefono'  => $user->telefono,
            'fecha_nac' => $user->fecha_nac,
            'rol'       => $user->rol->nombre ?? null,
            'foto_url'  => $user->foto ? asset('storage/' . $user->foto) : null,
            'contrato'  => $user->contrato ? [
                'cargo'         => $user->contrato->cargo->nombre ?? null,
                'departamento'  => $user->contrato->departamento->nombre ?? null,
                'grupo_calculo' => $user->contrato->grupoCalculo->nombre ?? null,
                'tipo_contrato' => $user->contrato->tipo_contrato,
                'fecha_ingreso' => $user->contrato->fecha_ingreso,
                'remuneracion'  => $user->contrato->remuneracion,
            ] : null,
            'clasificacion' => $clasificacion ? [
                'categoria' => $clasificacion->categoria,
                'perfil'    => $clasificacion->perfil,
                'nivel'     => $clasificacion->nivel,
                'puesto'    => $clasificacion->puesto,
            ] : null,
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'email'    => 'nullable|email|unique:users,email,' . $request->user()->id,
            'telefono' => 'nullable|string|max:15',
        ]);

        $user = $request->user();
        $user->update([
            'email'    => $request->email,
            'telefono' => $request->telefono,
        ]);

        return response()->json([
            'message' => 'Perfil actualizado correctamente',
            'user'    => $user,
        ]);
    }

    public function updateFoto(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $user = $request->user();

        if ($user->foto && Storage::disk('public')->exists($user->foto)) {
            Storage::disk('public')->delete($user->foto);
        }

        $path = $request->file('foto')->store('fotos', 'public');
        $user->update(['foto' => $path]);

        return response()->json([
            'message'  => 'Foto actualizada correctamente',
            'foto_url' => asset('storage/' . $path),
        ]);
    }

    public function escalaRangos(Request $request)
    {
        $user = $request->user()->load(['contrato.cargo']);

        if (!$user->contrato || !$user->contrato->cargo) {
            return response()->json(null);
        }

        $cargo = strtoupper(trim($user->contrato->cargo->nombre));
        $anio = date('Y');

        $escala = EscalaSalarial::where('anio', $anio)
            ->whereRaw('UPPER(TRIM(puesto)) = ?', [$cargo])
            ->first();

        if (!$escala) {
            return response()->json(null);
        }

        return response()->json([
            'junior'    => $escala->junior,
            'senior'    => $escala->senior,
            'master'    => $escala->master,
            'valor'     => $escala->valor,
            'modalidad' => $escala->modalidad,
        ]);
    }
}