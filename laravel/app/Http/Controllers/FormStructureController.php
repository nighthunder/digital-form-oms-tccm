<?php
// Controler das mudanças nas estruturas nos módulos dos questionários

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FormStructureController extends Controller
{

    public function updateUnpublishedFormQuestions (Request $request)
    {
        try {
          //dd($request->questionsdescriptions);
          $respostas = str_replace("{", "", $request->questionsdescriptions);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          $query_response = DB::select("CALL putQstModuleDescription('{$request->modulo}','{$respostas}')");
          return response()->json($query_response);

       } catch (Exception $e) {
         return response()->json($e, 500);
       }
    }

}
