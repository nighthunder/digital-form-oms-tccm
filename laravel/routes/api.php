<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\FormController;
use App\Http\Controllers\FormStructureController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\SurveyController;
use App\Http\Controllers\ModuleController;
use App\Http\Controllers\HospitalController;
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

    Route::get('survey/{id}', [SurveyController::class, 'show']); //Pesquisa
    Route::get('survey/', [SurveyController::class, 'search']);
    Route::post('survey/', [SurveyController::class, 'insert']);
    Route::post('survey/{formRecordId}', [SurveyController::class, 'update']);
    Route::post('searchSurvey/', [SurveyController::class, 'searchQuestionnaireDesc']);

    Route::get('modules/{id}', [ModuleController::class, 'search']); // Todos os módulos da pesquisa
    Route::get('mothermodules/{id}', [ModuleController::class, 'getQuestionnaireMotherModules']); // Todos os módulos da mãe da pesquisa
    Route::post('searchModules/', [ModuleController::class, 'searchModuleDesc']); // Campo de busca
    Route::post('module/', [ModuleController::class, 'insert']); 
    Route::post('module/{id}', [ModuleController::class, 'show']); 
    Route::get('questiontype/{id}', [ModuleController::class, 'getQuestionTypeAltText']); 

    Route::post('searchHospital/', [HospitalController::class, 'searchHospitalDesc']);

    Route::put('formqstdesc/{id}', [FormStructureController::class, 'updatePublishedFormQuestions']);
    Route::put('formgroupsdesc/{id}', [FormStructureController::class, 'updatePublishedFormQuestionsGroups']);
    Route::put('formqstorder/{id}', [FormStructureController::class, 'updateQstChangeOrder']);
    Route::put('formgroup/', [FormStructureController::class, 'postQstGroup']);
    Route::put('formqst/', [FormStructureController::class, 'postQst']);
    Route::put('formqstgroup/', [FormStructureController::class, 'putQstGroup']);
    Route::put('formqsttype/', [FormStructureController::class, 'putQstType']);
    Route::put('formqstlisttype/', [FormStructureController::class, 'putQstListType']);
    Route::put('formqstsubordinateto/', [FormStructureController::class, 'putQstSubordinateTo']);
    Route::put('formqstsubordinatevalues/', [FormStructureController::class, 'putQstSubordinateValues']);
    Route::get('formgroupid/', [FormStructureController::class, 'getLastInsertedGroupID']);
    Route::get('formqstid/', [FormStructureController::class, 'getLastInsertedQstID']);

    Route::get('checkpublication/{id}', [FormStructureController::class, 'checkQuestionnairePublicationRules']); //verifica se o questionário tem condições de ser publicado

});


