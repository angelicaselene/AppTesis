<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GrupoCalculo extends Model
{
    protected $table = 'grupo_calculos';

    protected $fillable = [
        'nombre'
    ];

    public function contratos()
    {
        return $this->hasMany(Contrato::class);
    }
}