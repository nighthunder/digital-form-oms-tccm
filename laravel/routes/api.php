<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\FormController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\SurveyController;
use App\Http\Controllers\MedicalRecordController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::group(['middleware' => 'cors:api'], function() {
    Route::post('register/', [UserController::class, 'register']);
    Route::post('login/', [UserController::class, 'login']);

    Route::post('insertMedicalRecord/', [MedicalRecordController::class, 'insert']);
    Route::post('searchMedicalRecord/', [MedicalRecordController::class, 'getModulesMedicalRecord']);
    Route::post('editMedicalRecord/', [MedicalRecordController::class, 'edit']);

    Route::get('form/{id}', [FormController::class, 'show']); // obtenção das perguntas de um formulário
    Route::get('formResponses/{formRecordId}', [FormController::class, 'responses']);
    Route::get('form/', [FormController::class, 'search']);
    Route::post('form/{id}', [FormController::class, 'store']);
    Route::put('form/{id}', [FormController::class, 'update']);

    Route::get('survey/{id}', [SurveyController::class, 'show']);
    Route::get('survey/', [SurveyController::class, 'search']);
    Route::post('survey/', [SurveyController::class, 'insert']);
});


