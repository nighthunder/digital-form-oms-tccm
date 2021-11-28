import React from "react";
import { BrowserRouter, Redirect, Route, Switch } from "react-router-dom";

import Login from "./pages/Login";
import Cadastro from "./pages/Cadastro";
import Hospital from "./pages/Hospital";
import AddSurvey from "./pages/AddSurvey";
import ShowSurvey from "./pages/ShowSurvey";
import AddModule from "./pages/AddModule";
import Prontuario from "./pages/Prontuario";
import Modulos from "./pages/Modulos";
import Formulario from "./pages/Formulario";
import AddProntuario from "./pages/AddProntuario";
import EditProntuario from "./pages/EditProntuario";

export default function Routes() {

  return (
    <BrowserRouter>
      <Switch>
        <Route path="/" component={Login} exact />
        <Route path="/login" component={Login} exact />
        <Route path="/cadastro" component={Cadastro} exact />
        <Route path="/hospital" component={Hospital} exact />
        <Route path="/add-survey" component={AddSurvey} exact />
        <Route path="/show-survey" component={ShowSurvey} exact />
        <Route path="/add-module" component={AddModule} exact />
        <Route path="/prontuario" component={Prontuario} exact />
        <Route path="/add-prontuario" component={AddProntuario} exact />
        <Route path="/editar-prontuario" component={EditProntuario} exact />
        <Route path="/modulos" component={Modulos} exact />
        <Route path="/formulario" component={Formulario} exact />
      </Switch>
    </BrowserRouter>
  );
}
