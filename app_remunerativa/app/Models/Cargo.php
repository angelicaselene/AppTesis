<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cargo extends Model
{
    protected $table = 'cargos';

    protected $fillable = [
        'nombre'
    ];

    public function contratos()
    {
        return $this->hasMany(Contrato::class);
    }
}