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

	const [modules, setModules] = useState([]);

	useEffect(() => {
        async function loadModules() {
            const response = await api.get('/modules/'+location.state.questionnaireID);
            setModules(response.data);
			console.log("Resposta2", user);
			console.log("Resposta4", modules);
			console.log("Resposta3", location.state);
        }                                                                                                                                                                                                       
        loadModules();
    }, [])

	function getPtBrDate(somedate) {
        //var today = new Date();
        var dd = String(somedate.getDate()).padStart(2, '0');
        var mm = String(somedate.getMonth() + 1).padStart(2, '0');
        var yyyy = somedate.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

	return (

	  <main className="container">
	    <div className="module">
			<h2>{location.state.description}</h2>
			<div className="survey-details">
				<p>Versão: {location.state.version}</p><br/>
				<p className="padding-10">Status: {location.state.questionnaireStatus}</p><br/>
				<p>Data de criação: {location.state.creationDate}</p><br/>
				<p className="padding-10">Última modificação: {location.state.lastModification}</p><br/>
			</div>
			<div className="modules-list">
				<table>
					<thead>
						<tr>
							<th>FORMULÁRIO</th>
							<th>STATUS</th>
							<th>CRIADO EM</th> 
							<th>MODIFICADO EM</th> 
						</tr>
					</thead>
					<tbody>
					{
                              modules.map(q => ( 
                                    <tr key={q.questionnaireID} data-key={q.questionnaireID} onClick={ () => {
                                    history.push('/show-survey/',
									{questionnaireID: q.questionnaireID, 
                                    description : q.description,
                                    version : q.version,
                                    questionnaireStatus : q.questionnaireStatus,
                                    lastModification: getPtBrDate(new Date(q.lastModification)),
                                    creationDate: getPtBrDate(new Date(q.creationDate))
                                    })
                                    }}>
                                        <td>{q.description}</td>
                                        <td>{q.crfFormsStatus}</td>
                                        <td>{getPtBrDate(new Date(q.creationDate))}</td> 
                                        <td>{getPtBrDate(new Date(q.lastModification))}</td> 
                                    </tr>
                               ))
                     }
					</tbody>
				</table>
			</div>
			 <Button variant="outlined" color="primary" className="add-module" onClick={ () => {
				history.push('/add-module',  
				{questionnaireID: location.state.questionnaireID, 
								  description : location.state.description,
                                  version : location.state.version,
                                  questionnaireStatus : location.state.questionnarieStatus,
                                  lastModification: location.state.lastModification,
                                  creationDate: location.state.creationDate
                })
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