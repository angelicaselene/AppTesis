<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ExcelController;
use App\Http\Controllers\Api\PerfilController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\MofController;
use App\Http\Controllers\Api\UsuariosController;
use App\Http\Controllers\Api\EscalaController;
use App\Http\Controllers\Api\AnalisisSalarialController;
use App\Http\Controllers\Api\HistorialController;
use App\Http\Controllers\Api\DetalleEscalaController;



// Rutas públicas
Route::post('/login', [AuthController::class, 'login']);

// Rutas protegidas con Sanctum
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);

    // Perfil del usuario autenticado
    Route::get('/perfil', [PerfilController::class, 'show']);

    // Home RR.HH - indicadores clave
    Route::get('/home/indicadores', [HomeController::class, 'indicadores']);

    // Clasificación de puestos (MOF)
    Route::get('/mof', [MofController::class, 'index']);
    Route::get('/mof/categorias', [MofController::class, 'categorias']);

    // Importación Excel
    Route::post('/importar-usuarios', [ExcelController::class, 'importar']);
    Route::get('/usuarios', [UsuariosController::class, 'index']);

    Route::put('/perfil', [PerfilController::class, 'update']);
    Route::get('/usuarios/{id}/valuacion', [UsuariosController::class, 'valuacion']);
    Route::post('/perfil/foto', [PerfilController::class, 'updateFoto']);
    Route::get('/escala/anios', [EscalaController::class, 'anios']);
    Route::get('/escala', [EscalaController::class, 'index']);
    Route::get('/analisis-salarial', [AnalisisSalarialController::class, 'index']);
    Route::get('/historial', [HistorialController::class, 'index']);
    Route::get('/perfil/escala-rangos', [PerfilController::class, 'escalaRangos']);
    Route::get('/analisis-salarial/rangos', [AnalisisSalarialController::class, 'rangos']);
    Route::get('/detalle-escala', [DetalleEscalaController::class, 'index']);


});