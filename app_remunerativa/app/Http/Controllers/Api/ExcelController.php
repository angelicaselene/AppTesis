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

        // Guardar archivo temporalmente para PHPSpreadsheet
        $path = $file->storeAs('temp', 'excel_import.' . $file->getClientOriginalExtension());
        $fullPath = storage_path('app/' . $path);

        // Guardar historial antes de sobreescribir
        $this->guardarHistorial();

        // Importar clasificación primero
        Excel::import(new ClasificacionImport, $file);

        // Importar usuarios
        Excel::import(new UsuariosImport, $file);

        // Importar escala salarial
        $this->importarEscala($fullPath);

        // Eliminar archivo temporal
        \Storage::delete($path);

        return response()->json([
            'message' => 'Excel importado correctamente'
        ]);
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

        // Insertar en lotes de 100
        if (count($batch) >= 100) {
            EscalaSalarial::insert($batch);
            $batch = [];
        }
    }

    // Insertar restantes
    if (!empty($batch)) {
        EscalaSalarial::insert($batch);
    }
}
}