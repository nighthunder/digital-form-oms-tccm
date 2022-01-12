<?php

// Controle das pesquisas (Versionamento de questionários)

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ModuleController extends Controller
{
    public function search($id) // obtem metadados de todos os formulários (modulos) de uma pesquisa
    {
        return response()->json(DB::select("CALL getAllModules({$id})"));
    }

    public function insert(Request $request)  // cria uma formulário novo
    {
        try {
            $query_msg = DB::select("CALL postModule('{$request->userid}',
                                                            '{$request->grouproleid}',
                                                            '{$request->hospitalunitid}',
                                                            '{$request->description}',
                                                            '{$request->moduleStatusID}',
                                                            '{$request->questionnaireID}',
                                                            '{$request->lastModification}',
                                                            '{$request->creationDate}')");
            $query_msg = $query_msg[0];
            /*if($query_msg->msgRetorno == 'Informe uma descrição para a pesquisa. '
            || $query_msg->msgRetorno == 'Usuário não identificado. Verifique'
            || $query_msg->msgRetorno == 'Hospital não identificado no cadastro. Verifique.') {
                return response()->json($query_msg, 404);
            }

            if($query_msg->msgRetorno) {
                if($query_msg->msgRetorno == 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!') {
                    return response()->json($query_msg, 404);
                }
            }  */  

            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    }

    public function searchModuleDesc(Request $request) {
        try {
            $query_msg = DB::select("CALL searchModule(
                                        '{$request->descricao}',
                                        '{$request->questionnaireID}')");
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    } 

    public function getQuestionTypeAltText($id) 
    {
        return response()->json(DB::select("CALL getQuestionTypeAltText({$id})"));
    }

}

