<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('valuacion_puestos', function (Blueprint $table) {
            $table->id();
            $table->string('categoria')->nullable();
            $table->string('puesto');
            $table->integer('formacion_profesional')->default(0);
            $table->integer('investigacion')->default(0);
            $table->integer('experiencia')->default(0);
            $table->integer('excelencia_servicio')->default(0);
            $table->integer('capacidad_resolutiva')->default(0);
            $table->integer('emprendimiento')->default(0);
            $table->integer('innovacion')->default(0);
            $table->integer('competencia_digital')->default(0);
            $table->integer('mental')->default(0);
            $table->integer('emocional')->default(0);
            $table->integer('fisico')->default(0);
            $table->integer('cumplimiento_metas')->default(0);
            $table->integer('responsabilidades_financieras')->default(0);
            $table->integer('prestacion_servicios')->default(0);
            $table->integer('confidencialidad')->default(0);
            $table->integer('manejo_materiales')->default(0);
            $table->integer('manejo_personas')->default(0);
            $table->integer('riesgo_ambiental')->default(0);
            $table->integer('riesgo_psicologico')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('valuacion_puestos');
    }
};