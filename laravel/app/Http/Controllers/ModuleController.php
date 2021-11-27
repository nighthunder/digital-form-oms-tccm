<?php

// Controle das pesquisas (Versionamento de questionários)

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ModuleController extends Controller
{
    public function search($id) // obtem metadados de todos os formulários de modulos de um questionário (pesquisa)
    {
        return response()->json(DB::select("CALL getAllModules({$id})"));
    }
}

