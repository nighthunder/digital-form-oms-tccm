// Lista de todas as pesquisas

import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import { Button, TextField, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function ListSurvey({user, hospital}) {

    const location = useLocation();

    const history = useHistory();

    const [questionnaires, setQuestionnaires] = useState([]);

    useEffect(() => {
        async function loadQuestionnaires() {
            const response = await api.get('/survey');
            setQuestionnaires(response.data);
        }
        loadQuestionnaires();

    }, [])

    function getPtBrDate(somedate) {
        //var today = new Date();
        var dd = String(somedate.getDate()).padStart(2, '0');
        var mm = String(somedate.getMonth() + 1).padStart(2, '0');
        var yyyy = somedate.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

	return (
            <div className="survey">
				<h2>Criação e edite pesquisas</h2>
               
                <div className="surveys-list">
                    <table>
                            <thead>
                                <tr>
                                    <th>PESQUISA</th>
                                    <th>VER.</th> 
                                    <th>STATUS</th>
                                    <th>CRIADO EM</th> 
                                    <th>MODIFICADO EM</th> 
                                </tr>
                            </thead>
                            <tbody>
                            {
                                questionnaires.map(q => ( 
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
                                        <td>{q.version}</td>
                                        <td>{q.questionnaireStatus}</td>
                                        <td>{getPtBrDate(new Date(q.creationDate))}</td> 
                                        <td>{getPtBrDate(new Date(q.lastModification))}</td> 
                                    </tr>
                            
                                 ))
                             }
                             </tbody>
                            
                    </table>
                    <Button variant="outlined" color="primary" className="add-survey" onClick={ () => {
                    history.push('/add-survey')
                    }}>
                    <Add color="primary" />
                    Adicionar nova Pesquisa
                    </Button>
                </div>
			</div>
     );

}

export default connect(state => ({ user: state.user }))(ListSurvey);