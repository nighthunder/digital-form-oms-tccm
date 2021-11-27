import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import ReactDOM from 'react-dom';
import { TextField, Button, InputLabel, FormLabel, Select, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

const styles = {
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function AddModule({user}) {

    const history = useHistory();

    const location = useLocation();

    const [formError, setFormError] = useState('')

    const [module, setModule] = useState('');

    const [creationDate, setCreationDate] = useState('');

    const [loading, setLoading] = useState(false);

    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    function convertToDate(somedate){
        return String(somedate.getFullYear()+
              "-"+(somedate.getMonth()+1)+
              "-"+somedate.getDate()+
              " "+somedate.getHours()+
              ":"+somedate.getMinutes()+
              ":"+somedate.getSeconds());
    }

    async function handleSubmit(e) {
        e.preventDefault();
        setLoading(true);
       
       const param = {
            userid : user[0].userid,    
            grouproleid : user[0].grouproleid,    
            hospitalunitid : user[0].hospitalunitid,    
            questionnaireID: location.state.questionnaireID,
            description: module,
            moduleStatusID: "2", // New
            lastModification: creationDate,
            creationDate: creationDate
       }
       console.log("request", param);
       const response = await api.post('/module/', param).catch( function (error) {
            setLoading(false);
            console.log(error)
            if(error.response.data.Message) {
                setError(error.response.data.Message);
            } else {
                setError(error.response.data.msgRetorno);
            }
        });

       if(response) {
            setLoading(false);
            setSuccess(response.data.msgRetorno);
            history.push("show-survey/", location.state.questionnaireID);
        }
    }

    function handleChange(e) {
        setError('');
        //console.log(user)
        setModule(e.target.value)
        console.log(module);
        setCreationDate(convertToDate(new Date()));
    }

    return (
            <main className="container">
                <p className="subtitle"> Adicione um novo formulário na pesquisa:</p>
                <h2>{location.state.description}</h2>
			    <div className="survey-details">
				    <p>Versão: {location.state.version}</p><br/>
				    <p className="padding-10">Status: {location.state.questionnaireStatus}</p><br/>
				    <p>Data de criação: {location.state.creationDate}</p><br/>
				    <p className="padding-10">Última modificação: {location.state.lastModification}</p><br/>
			    </div>
                <form className="module" onSubmit={handleSubmit}>
                    <div className="formGroup">
                        <InputLabel>Dê um nome para o seu formulário: </InputLabel><br/>
                        <TextField name="survey" label="Descrição" onChange={handleChange} value={module}/>
                    </div>
                    <div className="submit-prontuario">
                        <span className="error">{ error }</span>
                        <span className="success">{ success }</span>
                        <br/>
                        <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!module}>
                            { !loading &&
                                'Registrar novo formulário'
                            }
                            { loading &&
                                <CircularProgress color="white"/>
                            }
                        </Button>
                    </div>
                 </form>
            </main>
    );
}

export default connect(state => ({ user: state.user }))(AddModule);