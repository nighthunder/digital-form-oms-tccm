<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MedicalRecordController extends Controller
{
    public function insert(Request $request)
    {
        try {
            $query_msg = DB::select("CALL postMedicalRecord('{$request->userid}',
                                                            '{$request->groupRoleid}',
                                                            '{$request->hospitalUnitid}',
                                                            '{$request->questionnaireId}',
                                                            '{$request->medicalRecord}',
                                                             @p_msg_retorno)");
            $query_msg = $query_msg[0];
            if($query_msg->msgRetorno == 'Informe o numero do prontuário eletronico para cadastro. '
            || $query_msg->msgRetorno == 'Prontuário já registrado para o Hospital.'
            || $query_msg->msgRetorno == 'Erro no registro do Prontuario Medico. Verifique!'
            || $query_msg->msgRetorno == 'Hospital não identificado no cadastro. Verifique.') {
                return response()->json($query_msg, 404);
            }

            if($query_msg->msgRetorno) {
                if($query_msg->msgRetorno == 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!') {
                    return response()->json($query_msg, 404);
                }
            }

            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
        
    }

    public function getModulesMedicalRecord(Request $request) {
        try {
            $query_msg = DB::select("CALL getModulesMedicalRecord('{$request->medicalRecord}', {$request->hospitalUnitId})");
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    } 

    public function edit(Request $request) {
        try {
            $query_msg = DB::select("CALL putMedicalRecord('{$request->userid}',
                                                           '{$request->groupRoleid}',
                                                           '{$request->hospitalUnitid}',
                                                           '1',
                                                           '{$request->participantId}',
                                                           '{$request->medicalRecordNew}',
                                                           @p_msg_retorno)");
            $query_msg = $query_msg[0];
            if($query_msg->msgRetorno !== 'Alteração realizada com sucesso.') {
                return response()->json($query_msg, 404);
            }
            
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    }
}
