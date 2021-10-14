import React, { useState } from 'react';
import { useLocation } from "react-router-dom";
import './styles.css';
import { useHistory } from "react-router-dom";
import { TextField, Button, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';

import { connect } from 'react-redux';

import api from '../../services/api';

function setParticipantId(participantId) {
    return {
      type: 'STORE_PARTICIPANT_ID',
      participantId: participantId
    }
  }

function Prontuario({user, dispatch}) {

    const [search, setSearch] = useState('');
    const [error, setError] = useState('');
    const [modules, setModules] = useState([]);
    const [modulesLoaded, setModulesLoaded] = useState(false);
    const [loadingSearch, setLoadingSearch] = useState(false);

    const history = useHistory();

    const location = useLocation();

    async function handleSearch(e) {
        e.preventDefault();
        setError('');
        setLoadingSearch(true);
        setModulesLoaded(false);
        const response = await api.post('/searchMedicalRecord', {
            medicalRecord: search,
            hospitalUnitId: user[location.state.hospitalIndex].hospitalunitid,
        }).catch( function (error) {
            setLoadingSearch(false);
            console.log(error)
            console.log(error.response.data)
        });
       
        if(response.data) {
            setLoadingSearch(false);
            setModulesLoaded(true);
            if(response.data.length > 0) {
                dispatch(setParticipantId(response.data[0].participantID));
                if(response.data[0].msgRetorno) {
                    setError(response.data[0].msgRetorno)
                } else {
                    setError('')
                }
            }

            for(let record of response.data) {
                record.dataRefer = new Date(record.dataRefer);
                record.dtRegistroSystem = new Date(record.dtRegistroSystem);
                switch (record.crfformsid) {
                    case 1:
                        record['moduleName'] = 'Admissão'
                        break;
                    case 2:
                        record['moduleName'] = 'Acompanhamento'
                        break;
                    case 3:
                        record['moduleName'] = 'Alta ou Morte'
                        break;
                    
                  }
            }
        }

        setModules(response.data)
        console.log(response.data);
    }

    function toForm(prontuario) {
        console.log('prontuário escolhido: ', prontuario);
        history.push('/modulos');
    }

    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        console.log(value);
        setSearch(value);
    }


    return (
        <main className="container prontuarios">
            <div>
                <header className="index">
                    <b>{location.state.hospitalName}</b>
                </header>
                <h2>Prontuário</h2>
            </div>
            <div className="prontuario-options">
                <form noValidate autoComplete="off" onSubmit={handleSearch}>
                    <TextField id="standard-basic" label="Nº Prontuário" onChange={handleChange}/>
                    <Button variant="contained" color="primary" type="submit">
                        { !loadingSearch &&
                            'Buscar'
                        }
                        { loadingSearch &&
                            <CircularProgress color="white"/>
                        }
                    </Button>
                </form>
                <Button variant="outlined" color="primary" className="add-prontuario" onClick={ () => {
                    history.push('/add-prontuario', { hospitalIndex: location.state.hospitalIndex })
                }}>
                    <Add color="primary" />
                    Novo Prontuário
                </Button>
            </div>
            { (error) &&
                <span className="error">{ error }</span>
            }
            <div className="prontuario-result">
                { modulesLoaded && !error &&
                    <div className="title-table">
                        <h4>Módulos cadastrados do prontuário { modules.length > 0 ? modules[0].medicalRecord : search }
                        <Edit onClick={ () => {
                            history.push('/editar-prontuario', { hospitalIndex: location.state.hospitalIndex,
                                                                 prontuario: modules.length > 0 ? modules[0].medicalRecord : search,
                                                                 participantId: modules[0].participantID })
                        }}/>
                        </h4>
                        <Button variant="outlined" color="primary" className="add-modulo" onClick={ () => {
                            history.push('/modulos', { hospitalIndex: location.state.hospitalIndex,
                                                       prontuario: modules.length > 0 ? modules[0].medicalRecord : search,
                                                       registeredModules: modules[0].formrecordid ? modules : [] })
                        }}>
                            <Add color="primary" />
                            Novo lançamento de módulo
                        </Button>
                    </div>
                }
                { modules.length > 0 && modulesLoaded && !error && modules[0].formrecordid &&
                    <table>
                        <thead>
                            <tr>
                                <th>Formulário</th>
                                <th>Data</th> 
                                <th>Questões respondidas(%)</th>
                            </tr>
                        </thead>
                        <tbody>
                            {modules.map((module, index) => (
                                <tr key={module.formrecordid} className="data-items" onClick={ () => {
                                    history.push('/formulario', { modulo: module.crfformsid,
                                                                  formRecordId: module.formrecordid,
                                                                  hospitalIndex: location.state.hospitalIndex,
                                                                  registeredModules: modules[0].formrecordid ? modules : [] })
                                }}>
                                    <td>{ module.moduleName }</td>
                                    <td>{ module.dataRefer.getDate() + 1 }/{ module.dataRefer.getMonth() + 1 }/{ module.dataRefer.getFullYear() }</td>
                                    <td>{ Math.ceil(module.questionAnswerTot * 100 / module.questionTot) }%</td>
                                </tr>
                                
                            ))}
                        </tbody>
                    </table>
                }
            </div>
            
        </main>
    );
}

export default connect(state => ({ user: state.user }))(Prontuario);