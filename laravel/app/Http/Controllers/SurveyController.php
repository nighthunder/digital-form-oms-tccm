<?php

// Controle das pesquisas (Versionamento de questionários)

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SurveyController extends Controller
{
    public function show($id) // procedure que obtem as perguntas de um formulário
    {
        return response()->json(DB::select("CALL getQuestionnaire({$id})"));
    }

}
