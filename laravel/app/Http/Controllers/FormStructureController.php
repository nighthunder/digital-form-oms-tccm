<?php
// Controler das mudanças nas estruturas nos módulos dos questionários

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FormStructureController extends Controller
{

    public function updatePublishedFormQuestions (Request $request)
    {
        try {
          $respostas = str_replace("{", "", $request->questionsdescriptions);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstModuleDescription('{$request->modulo}','{$respostas}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function updatePublishedFormQuestionsGroups (Request $request)
    {
        try {
          $respostas = str_replace("{", "", $request->questionsgroups);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstGroupModuleDescription('{$request->modulo}','{$respostas}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

}
