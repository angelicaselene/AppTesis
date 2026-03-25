<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('contratos', function (Blueprint $table) {
            $table->id();
            $table->string('tipo_contrato');
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('departamento_id')->constrained('departamentos');
            $table->foreignId('cargo_id')->constrained('cargos');
            $table->foreignId('grupo_calculos_id')->constrained('grupo_calculos');
            $table->decimal('remuneracion',10,2);
            $table->date('fecha_ingreso');
            $table->date('fecha_fin')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contratos');
    }
};
