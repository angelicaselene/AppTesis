<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Contrato extends Model
{
    protected $table = 'contratos';

    protected $fillable = [
        'user_id',
        'cargo_id',
        'departamento_id',
        'grupo_calculos_id',
        'tipo_contrato',
        'remuneracion',
        'fecha_ingreso'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function cargo()
    {
        return $this->belongsTo(Cargo::class);
    }

    public function departamento()
    {
        return $this->belongsTo(Departamento::class);
    }

    public function grupoCalculo()
    {
        return $this->belongsTo(GrupoCalculo::class, 'grupo_calculos_id');
    }
}