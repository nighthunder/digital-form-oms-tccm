<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Hash;

class UserController extends Controller
{
    public function register(Request $request)
    {
        try {
            $query_msg = DB::select("CALL postuser('".$request->adminId."',
                                                '".$request->adminGroupRoleid."',
                                                '".$request->hospitalUnitId."' ,
                                                '".$request->email."',
                                                '".$request->nome."',
                                                '".$request->sobrenome."',
                                                '".$request->crm."',
                                                '".$request->senha."' ,
                                                '".$request->email."',
                                                '".$request->telefone."',
                                                '".$request->funcao."',
                                                @p_userid,
                                                @p_msg_retorno);");

            // $query_msg = $query[0]->p_msg_retorno;

            if($query_msg == 'Campos obrigatórios devem ser preenchidos. Verifique.'
            || $query_msg == 'Login já existe. Verifique.'
            || $query_msg == 'e-mail já cadastrado no sistema. Verifique.'
            || $query_msg == 'Ocorreu um erro durante a execução do procedimento. Contacte o administrador!'
            || $query_msg == 'Hospital não identificado no cadastro. Verifique.'
            || $query_msg == 'Selecione um papel a ser exercido junto ao Hospital. '
            || $query_msg == 'Problemas na inclusão de informações. Verifique.') {
                return response()->json($query_msg, 404);
            }
            return response()->json($query_msg);
        } catch(Exception $e) {
            return response()->json($e, 500);
        }
    }

    public function login(Request $request)
    {
        try {

            //echo "<pre>";
            //var_dump($request);
            //echo "</pre>";
            $query = DB::select("CALL getuser('{$request->login}', '{$request->password}')");
            if($query) {
                return response()->json($query);
            } else {
               return response()->json('Email ou senha incorreta.', 403);
            }
        } catch(Expection $e) {
            return response()->json($e, 500);
        }
    }
}

