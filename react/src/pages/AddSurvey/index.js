import React, { useState } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { HashLink } from 'react-router-hash-link';
import api from '../../services/api';
import { TextField, Button, InputLabel, CircularProgress } from '@material-ui/core';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import './styles.css';

import { connect } from 'react-redux';

const styles = {
  TextField: {
    
  },
  Button: {
    margin: 24,
    marginBottom: 0
  }
};

function AddSurvey({user}) {

    const history = useHistory();

    //console.log("history addsurvey", history);

    const location = useLocation();

    //console.log("history addsurvey", location);

    const [formError, setFormError] = useState('')

    const [survey, setSurvey] = useState('');

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
            description: survey,
            version: "0.0",
            questionnaireStatusID: "2", // New
            creationDate: creationDate,
            lastModification: creationDate
       }
       console.log("request", param);
       const response = await api.post('/survey', param).catch( function (error) {
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
            history.push("hospital/");
        }
    }

    function handleChange(e) {
        setError('');
        //console.log(user)
        console.log("Location pesq", location)
        setSurvey(e.target.value)
        //console.log(survey);
        setCreationDate(convertToDate(new Date()));
    }
    
    function handleBackButton(){
        history.goBack();
    }

    return (
        <div>
            <main className="container add-survey" id="topo">
                <div className="mainNav">
				    <h2>Adicione uma nova pesquisa clínica:</h2>
                    <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                    <HashLink to='/add-survey#topo'>
                            <ArrowUpwardIcon className="ArrowUp" />
                    </HashLink>
                </div>
                <div>
                 <form className="module" onSubmit={handleSubmit}>
                    <div className="formGroup">
                        <InputLabel>Digite a descrição para sua pesquisa (pt-br): (versão: 0.0) </InputLabel>
                        <TextField className="inputDescription" name="survey" label="Descrição" onChange={handleChange} value={survey} style={styles.TextField} />
                    </div>
                    <div className="submit-prontuario">
                        <span className="error">{ error }</span>
                        <span className="success">{ success }</span>
                        <br/>
                        <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!survey}>
                            { !loading &&
                                'Salvar'
                            }
                            { loading &&
                                <CircularProgress color="white"/>
                            }
                        </Button>
                    </div>
                 </form>
                </div>
            </main>
        </div>
    );
}

export default connect(state => ({ user: state.user }))(AddSurvey);