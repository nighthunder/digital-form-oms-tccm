<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FormController extends Controller
{
    public function show($id)
    {
        return response()->json(DB::select("CALL getqst_rsp_modulo('{$id}')"));
    }

    public function store(Request $request)
    {
        $one = 1;
        try {
            /* $query_response = DB::select("CALL postmoduloMedicalRecord('{$request->info['userid']}','{$request->info['grouproleid']}','{$request->info['hospitalunitid']}','{$request->participantId}','{$one}','{$request->modulo}','{$request->dataAcompanhamento}', @p_msg_retorno_one, @p_msg_retorno_two)");
            $d = json($query_response); */

            $respostas = str_replace("{", "", $request->respostas);

            $respostas = str_replace("}", "", $respostas);
            $respostas = str_replace('"', "", $respostas);

            $query_response = DB::select("CALL postQstModuloMedicalRecord('{$request->info['userid']}','{$request->info['grouproleid']}','{$request->info['hospitalunitid']}','{$request->participantId}','{$one}','{$request->modulo}','{$respostas}', @p_msg_retorno_one, @p_msg_retorno_two)");

            return response()->json($query_response);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function update(Request $request)
    {
        $one = 1;
        try {
            $respostas = str_replace("{", "", $request->respostas);

            $respostas = str_replace("}", "", $respostas);
            $respostas = str_replace('"', "", $respostas);

            $query_response = DB::select("CALL putqstmoduloMedicalRecord('{$request->info['userid']}','{$request->info['grouproleid']}','{$request->info['hospitalunitid']}','{$request->participantId}','{$one}','{$request->modulo}', '{$request->formRecordId}', '{$respostas}', @p_msg_retorno)");

            return response()->json($query_response);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function search(){
        return response()->json(DB::select("CALL getcrfForms('1')"));
    }

    public function responses($formRecordId)
    {
        try {
            $query_response = DB::select("CALL getqst_rsp_modulo_medicalRecord('{$formRecordId}')");
            return response()->json($query_response);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }
}