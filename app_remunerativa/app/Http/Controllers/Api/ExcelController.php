<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\UsuariosImport;
use App\Imports\ClasificacionImport;
use App\Models\User;
use App\Models\EscalaSalarial;
use App\Models\HistorialSalarial;
use App\Models\HistorialRemuneracion;
use PhpOffice\PhpSpreadsheet\IOFactory;

class ExcelController extends Controller
{
    public function importar(Request $request)
    {
        set_time_limit(300);

        $request->validate([
            'archivo' => 'required|file|mimes:xlsx,xls'
        ]);

        $file = $request->file('archivo');

        $path = $file->storeAs('temp', 'excel_import.' . $file->getClientOriginalExtension());
        $fullPath = storage_path('app/' . $path);

        $this->guardarHistorial();

        Excel::import(new ClasificacionImport, $file);
        Excel::import(new UsuariosImport, $file);

        $this->importarEscala($fullPath);
        $this->importarResumen($fullPath);

        \Storage::delete($path);

        return response()->json(['message' => 'Excel importado correctamente']);
    }

    private function guardarHistorial()
    {
        $users = User::with(['contrato.cargo'])->get();
        $batch = [];
        $now = now();

        foreach ($users as $user) {
            if (!$user->contrato) continue;
            $batch[] = [
                'user_id'      => $user->id,
                'cargo'        => $user->contrato->cargo->nombre ?? null,
                'remuneracion' => $user->contrato->remuneracion,
                'fecha'        => $now,
                'created_at'   => $now,
                'updated_at'   => $now,
            ];
        }

        if (!empty($batch)) {
            HistorialSalarial::insert($batch);
        }
    }

    private function importarEscala($path)
    {
        $reader = \PhpOffice\PhpSpreadsheet\IOFactory::createReaderForFile($path);
        $reader->setReadDataOnly(false);
        $spreadsheet = $reader->load($path);
        $ws = $spreadsheet->getSheetByName('ESCALA');
        if (!$ws) return;

        $anio = date('Y');
        $seccion = 'ACADÉMICOS';

        EscalaSalarial::where('anio', $anio)->delete();

        $highestRow = $ws->getHighestRow();
        $batch = [];

        for ($i = 4; $i <= $highestRow; $i++) {
            $cat    = trim((string)($ws->getCell('B'.$i)->getCalculatedValue() ?? ''));
            $perfil = trim((string)($ws->getCell('C'.$i)->getCalculatedValue() ?? ''));
            $nivel  = trim((string)($ws->getCell('D'.$i)->getCalculatedValue() ?? ''));
            $puesto = trim((string)($ws->getCell('E'.$i)->getCalculatedValue() ?? ''));
            $modal  = trim((string)($ws->getCell('F'.$i)->getCalculatedValue() ?? ''));
            $valor  = $ws->getCell('G'.$i)->getCalculatedValue();
            $junior = $ws->getCell('H'.$i)->getCalculatedValue();
            $senior = $ws->getCell('I'.$i)->getCalculatedValue();
            $master = $ws->getCell('J'.$i)->getCalculatedValue();

            if (!empty($cat) && str_contains(strtoupper($cat), 'ESCALA DE REMUNERACIONES')) {
                $seccion = str_contains(strtoupper($cat), 'ADMINISTRATIVOS')
                    ? 'ADMINISTRATIVOS' : 'ACADÉMICOS';
                continue;
            }

            if (strtoupper($cat) === 'CATEGORIA') continue;
            if (empty($puesto)) continue;

            $batch[] = [
                'anio'      => $anio,
                'seccion'   => $seccion,
                'categoria' => $cat,
                'perfil'    => $perfil,
                'nivel'     => $nivel,
                'puesto'    => $puesto,
                'modalidad' => $modal,
                'valor'     => is_numeric($valor) ? floatval($valor) : null,
                'junior'    => is_numeric($junior) ? floatval($junior) : null,
                'senior'    => is_numeric($senior) ? floatval($senior) : null,
                'master'    => is_numeric($master) ? floatval($master) : null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            if (count($batch) >= 100) {
                EscalaSalarial::insert($batch);
                $batch = [];
            }
        }

        if (!empty($batch)) {
            EscalaSalarial::insert($batch);
        }
    }

    private function importarResumen($path)
    {
        $reader = \PhpOffice\PhpSpreadsheet\IOFactory::createReaderForFile($path);
        $reader->setReadDataOnly(true);
        $spreadsheet = $reader->load($path);
        $ws = $spreadsheet->getSheetByName('RESUMEN');
        if (!$ws) return;

        HistorialRemuneracion::truncate();

        $highestRow = $ws->getHighestRow();
        $batch = [];
        $now = now();

        for ($i = 3; $i <= $highestRow; $i++) {
            $dni  = trim((string)($ws->getCell('B'.$i)->getValue() ?? ''));
            $cargo = trim((string)($ws->getCell('F'.$i)->getValue() ?? ''));
            $anio = $ws->getCell('K'.$i)->getValue();
            $mes  = trim((string)($ws->getCell('L'.$i)->getValue() ?? ''));
            $rem  = $ws->getCell('M'.$i)->getValue();

            if (empty($dni) || empty($mes)) continue;

            $batch[] = [
                'dni'          => $dni,
                'cargo'        => $cargo,
                'anio'         => $anio,
                'mes'          => $mes,
                'remuneracion' => is_numeric($rem) ? floatval($rem) : null,
                'created_at'   => $now,
                'updated_at'   => $now,
            ];

            if (count($batch) >= 200) {
                HistorialRemuneracion::insert($batch);
                $batch = [];
            }
        }

        if (!empty($batch)) {
            HistorialRemuneracion::insert($batch);
        }
    }
}