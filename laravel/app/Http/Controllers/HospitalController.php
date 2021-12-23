<?php

// Controle das pesquisas (Versionamento de questionários)

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HospitalController extends Controller
{
    public function searchHospitalDesc(Request $request) { 
        try {
            $query_msg = DB::select("CALL searchHospital(
                                        '{$request->descricao}',
                                        '{$request->userID}')");
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    } 

}

