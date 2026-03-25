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
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('nombre')->unique();
            $table->timestamps();
        });

        DB::table('roles')->insert([
            'nombre' => 'RR.HH',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('roles')->insert([
            'nombre' => 'DIR',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('roles')->insert([
            'nombre' => 'TRAB',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }    

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('roles');
    }
};
