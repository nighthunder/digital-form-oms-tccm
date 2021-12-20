// Lista de todas as pesquisas

import React, { useState, useEffect } from 'react';
import { useHistory, useLocation, Link } from "react-router-dom";
import { HashLink } from 'react-router-hash-link';
import api from '../../services/api';
import { Button, TextField, CircularProgress} from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import ArrowUpward from '@mui/icons-material/ArrowUpward';
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

    function handleBackButton(){
        history.goBack();
    }

	return (
            <main className="container containerWider" id="topo">
                <a href="#" ></a>
                <div className="survey">
                    <div className="mainNav">
				        <h2 id="title">Crie e edite pesquisas</h2>
                        <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                        <HashLink to='/survey#topo'>
                            <ArrowUpwardIcon className="ArrowUp" />
                        </HashLink>
                    </div>
                    <div className="survey-details">
                        Gerencie as pesquisas: : crie, versione, copie, edite e publique.
                    </div>
                    <div className="surveys-list">
                        <table>
                                <thead>
                                    <tr>
                                        <th>PESQUISA</th>
                                        <th>VER.</th> 
                                        <th>STATUS</th>
                                        <th>CRIADO EM</th> 
                                        <th>MODIFICADO EM</th> 
                                        <th>EDITAR</th> 
                                    </tr>
                                </thead>
                                <tbody>
                                {
                                    questionnaires.map(q => ( 
                                        <tr key={q.questionnaireID} data-key={q.questionnaireID} onClick={ () => {
                                        history.push('/show-survey/', 
                                        {
                                        questionnaireID: q.questionnaireID, 
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
                                            <td><Edit /></td>
                                        </tr>
                            
                                     ))
                                 }
                                 </tbody>
                            
                        </table>
                        <Button variant="outlined" color="primary" className="add-survey" onClick={ () => {
                        history.push('/add-survey')
                        }}>
                        <Add color="primary" />
                        Adicionar nova pesquisa
                        </Button>
                        <br/>
                    </div>
			    </div>
            </main>
     );

}

export default connect(state => ({ user: state.user }))(ListSurvey);