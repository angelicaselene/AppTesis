<?php

namespace App\Imports;

use App\Models\User;
use App\Models\Cargo;
use App\Models\Departamento;
use App\Models\GrupoCalculo;
use App\Models\Contrato;
use Carbon\Carbon;
use PhpOffice\PhpSpreadsheet\Shared\Date;
use Illuminate\Support\Facades\Hash;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithChunkReading;

class UsuariosSheetImport implements ToModel, WithHeadingRow, WithChunkReading
{
    public function model(array $row)
    {
        // Encabezados normalizados por WithHeadingRow:
        // n | n_doc | apellidos_y_nombres | sexo | grupo_calculo | cargo
        // departamento | fecha_de_ingreso | tipo_contrato | fecha_nac | remuneracion_afecta

        \Log::info(array_keys($row));
        return null;

        $dni = isset($row['n_doc']) ? trim($row['n_doc']) : null;
        if (empty($dni)) return null;

        $grupo = GrupoCalculo::firstOrCreate(['nombre' => trim($row['grupo_calculo'] ?? '')]);
        $cargo = Cargo::firstOrCreate(['nombre' => trim($row['cargo'] ?? '')]);
        $departamento = Departamento::firstOrCreate(['nombre' => trim($row['departamento'] ?? '')]);

        // Fecha de nacimiento
        $fechaNacimiento = null;
        if (!empty($row['fecha_nac'])) {
            try {
                if (is_numeric($row['fecha_nac'])) {
                    $fechaNacimiento = Date::excelToDateTimeObject($row['fecha_nac'])->format('Y-m-d');
                } else {
                    $fechaNacimiento = Carbon::createFromFormat('d/m/Y', trim($row['fecha_nac']))->format('Y-m-d');
                }
            } catch (\Exception $e) {
                $fechaNacimiento = null;
            }
        }

        $user = User::firstOrCreate(
            ['dni' => $dni],
            [
                'nombres'   => trim($row['apellidos_y_nombres'] ?? ''),
                'sexo'      => trim($row['sexo'] ?? ''),
                'fecha_nac' => $fechaNacimiento,
                'password'  => Hash::make($dni),
                'rol_id'    => 3, // TRAB por defecto
            ]
        );

        // Fecha de ingreso
        $fechaIngreso = null;
        if (!empty($row['fecha_de_ingreso'])) {
            try {
                if (is_numeric($row['fecha_de_ingreso'])) {
                    $fechaIngreso = Date::excelToDateTimeObject($row['fecha_de_ingreso'])->format('Y-m-d');
                } else {
                    $fechaIngreso = Carbon::parse($row['fecha_de_ingreso'])->format('Y-m-d');
                }
            } catch (\Exception $e) {
                $fechaIngreso = null;
            }
        }

        // Remuneración (viene como número entero en el Excel)
        $remuneracion = 0;
        if (!empty($row['remuneracion_afecta'])) {
            $remuneracion = (float) preg_replace('/[^0-9.]/', '', $row['remuneracion_afecta']);
        }

        Contrato::firstOrCreate(
            ['user_id' => $user->id],
            [
                'cargo_id'          => $cargo->id,
                'departamento_id'   => $departamento->id,
                'grupo_calculos_id' => $grupo->id,
                'fecha_ingreso'     => $fechaIngreso,
                'tipo_contrato'     => trim($row['tipo_contrato'] ?? ''),
                'remuneracion'      => $remuneracion,
            ]
        );

        return $user;
    }

    public function chunkSize(): int
    {
        return 100;
    }
}
