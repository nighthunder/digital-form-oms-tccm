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
          $respostas = str_replace("{", "", $request->qstgroups);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstGroupModuleDescription('{$request->modulo}','{$respostas}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function updateQstChangeOrder(Request $request) // Alterar as ordem de questões de grupos
    {
        try {
          $respostas = str_replace("{", "", $request->questionsorder);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstChangeOrder('{$request->modulo}','{$respostas}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function postQstGroup(Request $request) // Cria uma lista de novos grupos
    {
        try {
          $respostas = str_replace("{", "", $request->stringgroups);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL postQstGroup('{$respostas}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function postQst(Request $request) // Cria uma lista de novos grupos
    {
        try {
          $respostas = str_replace("{", "", $request->stringquestions);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $respostas2 = str_replace("{", "", $request->stringgroups);
          $respostas2 = str_replace("}", "", $resposta2);
          $respostas2 = str_replace('"', "", $respostas2);

          $query_msg = DB::select("CALL postQstGroup('{$respostas}', '{$respostas2}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedGroupID(Request $request) // Cria uma lista de novos grupos
    {
        try {

          $query_msg = DB::select("CALL getLastInsertedGroupID(@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedQstID(Request $request) // Cria uma lista de novos grupos
    {
        try {
          $query_msg = DB::select("CALL getLastInsertedQstID(@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function checkQuestionnairePublicationRules(Request $request) // Cria uma lista de novos grupos
    {
        try {
          $query_msg = DB::select("CALL checkQuestionnairePublicationRules('{$request->id}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

}
