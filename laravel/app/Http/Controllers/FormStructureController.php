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
          $respostas = str_replace("{", "", $request->questiondesc);
          $respostas = str_replace("}", "", $respostas);
          $respostas = str_replace('"', "", $respostas);

          //dd($request);

          $query_response = DB::select("CALL putQstModuleDescription(
                                                            '{$respostas}')");
          return response()->json($query_response);

       } catch (Exception $e) {
         //return response()->json($e, 500);
       }
    }

}
