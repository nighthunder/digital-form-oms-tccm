import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import { Button, TextField, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function Pesquisa({user}) {

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

	return (
            <div className="pesquisa">
				<h2>Selecione uma pesquisa</h2>
				<Button variant="outlined" color="primary" className="add-prontuario add-pesquisa" onClick={ () => {
                    history.push('/add-prontuario', { hospitalIndex: location.state.hospitalIndex })
                }}>
                    <Add color="primary" />
                    Adicionar nova Pesquisa
                </Button>
               
                <div className="pesquisas-list">
                    <table>
                            <thead>
                                <tr>
                                    <th>Pesquisa</th>
                                    <th>Versão</th> 
                                    <th>Criado em</th> 
                                    <th>Modificado</th> 
                                    <th>Status</th>
                                    <th>Copiar</th>
                                </tr>
                            </thead>
                            <tbody>
                            {
                                questionnaires.map(q => ( 
                                    <tr>
                                        <td>{q.description}</td>
                                        <td>{q.version}</td>
                                        <td>{q.creationDate}</td> 
                                        <td>{q.lastModification}</td> 
                                        <td>{q.questionnaireStatus}</td>
                                        <td>Criar</td>
                                    </tr>
                            
                                 ))
                             }
                             </tbody>
                            
                    </table>
                </div>
			</div>
     );

}

export default Pesquisa;