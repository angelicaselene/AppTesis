<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Departamento extends Model
{
    protected $table = 'departamentos';

    protected $fillable = [
        'nombre'
    ];

    public function contratos()
    {
        return $this->hasMany(Contrato::class);
    }
}