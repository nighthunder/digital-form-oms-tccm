<?php

// Controle das pesquisas (Versionamento de questionários)

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SurveyController extends Controller
{
    public function show($id) // obtem metadados de uma pesquisa
    {
        return response()->json(DB::select("CALL getQuestionnaire({$id})"));
    }

    public function search() // obtem todas as pesquisas
    {
        return response()->json(DB::select("CALL getAllQuestionnaires()"));
    }

    public function insert(Request $request)  // insere uma pesquisa nova no banco
    {
        try {
            $query_msg = DB::select("CALL postQuestionnaire('{$request->userid}',
                                                            '{$request->grouproleid}',
                                                            '{$request->hospitalunitid}',
                                                            '{$request->isnewversionof}',
                                                            '{$request->isbasedon}',
                                                            '{$request->description}',
                                                            '{$request->version}',
                                                            '2',
                                                            '{$request->lastModification}',
                                                            '{$request->creationDate}')");
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    }

    public function update(Request $request)  
    {
        try {
            $query_msg = DB::select("CALL putQuestionnaire('{$request->userid}',
                                                            '{$request->grouproleid}',
                                                            '{$request->hospitalunitid}',
                                                            '{$request->questionnaireid}',
                                                            '{$request->isNewVersionOf}',
                                                            '{$request->isBasedOn}',
                                                            '{$request->description}',
                                                            '{$request->version}',
                                                            '{$request->status}',
                                                            '{$request->lastModification}',
                                                            '{$request->creationDate}')");

            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    }

    public function searchQuestionnaireDesc(Request $request) {
        try {
            $query_msg = DB::select("CALL searchQuestionnaire(
                                        '{$request->descricao}')");
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    } 

}

