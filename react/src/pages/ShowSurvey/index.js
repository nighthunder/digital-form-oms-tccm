// Detalhe de uma pesquisa

import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import { Button, TextField, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function ShowSurvey({user}) {

	const location = useLocation();
	const history = useHistory();

	return (

	  <main className="container">
	    <div className="module">
			<h2>{location.state.description}</h2>
			<div className="survey-details">
				<p>Versão: {location.state.version}</p><br/>
				<p className="padding-10">Status: {location.state.questionnaireStatusID}</p><br/>
				<p>Data de criação: {location.state.creationDate}</p><br/>
				<p className="padding-10">Última modificação: {location.state.lastModification}</p><br/>
			</div>
			<div className="modules-list">
				<table>
					<thead>
						<tr>
							<th>FORMULARIO</th>
							<th>VER.</th> 
							<th>STATUS</th>
							<th>CRIADO EM</th> 
							<th>MODIFICADO EM</th> 
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
			 <Button variant="outlined" color="primary" className="add-module" onClick={ () => {
				history.push('/add-module')
			 }}>
				<Add color="primary" />
				Adicionar novo formulário de módulo +
			 </Button><br/>
			  <Button variant="outlined" color="primary" className="add-module publish" onClick={ () => {
				history.push('/survey-publish')
			 }}>
				<Add color="primary" />
				Publicar pesquisa
			 </Button>
		 </div>
      </main>

	);

}

export default connect(state => ({ user: state.user }))(ShowSurvey);