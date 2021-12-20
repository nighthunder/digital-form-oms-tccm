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
                                                            '{$request->description}',
                                                            '0.0',
                                                            '2',
                                                            '{$request->lastModification}',
                                                            '{$request->creationDate}')");
            /*$query_msg = $query_msg[0];
            if($query_msg->msgRetorno == 'Informe uma descrição para a pesquisa. '
            || $query_msg->msgRetorno == 'Usuário não identificado. Verifique'
            || $query_msg->msgRetorno == 'Hospital não identificado no cadastro. Verifique.') {
                return response()->json($query_msg, 404);
            }

            if($query_msg->msgRetorno) {
                if($query_msg->msgRetorno == 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!') {
                    return response()->json($query_msg, 404);
                }
            }    */

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

