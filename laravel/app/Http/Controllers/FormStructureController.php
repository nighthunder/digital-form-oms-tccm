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

          $respostas = str_replace("{", "", $request->stringgroups);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL postQstGroup('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function putQstGroup(Request $request) // Altera associação entre grupos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringgroups);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstGroup('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function putQstType(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringtypes);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstType('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function postQstListType(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringlisttypes);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL postListType('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }

    }

    public function putQstListType(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringqstlisttypes);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstListType('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }

    }


    public function postQstListOfValues(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringlistofvalues);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL postListOfValues('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }

    }

    public function putQstListTypeListOfValues(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringlisttypeslistofvalues);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putListTypeListOfValues('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function putQstSubordinateTo(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringsubordinateto);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstSubordinateTo('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function putQstSubordinateValues(Request $request) // Altera associação entre tipos e questões
    {
        try {

          $respostas = str_replace("{", "", $request->stringsubordinatevalues);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_msg = DB::select("CALL putQstSubordinateValues('{$respostas}',@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedGroupID(Request $request) 
    {
        try {

          $query_msg = DB::select("CALL getLastInsertedGroupID(@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedQstID(Request $request) 
    {
        try {
          $query_msg = DB::select("CALL getLastInsertedQstID(@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedListTypeID(Request $request) 
    {
        try {
          $query_msg = DB::select("CALL getLastInsertedListTypeID(@p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

    public function getLastInsertedListOfValuesID(Request $request) 
    {
        try {
          $query_msg = DB::select("CALL getLastInsertedListOfValuesID(@p_msg_retorno)");
        
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

    public function publication(Request $request) // Publica um questionário e seus módulos
    {
        try {
          $query_msg = DB::select("CALL publishQuestionnaire('{$request->id}', @p_msg_retorno)");
        
          return response()->json($query_msg);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

}
