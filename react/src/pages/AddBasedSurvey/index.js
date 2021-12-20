import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { HashLink } from 'react-router-hash-link';
import api from '../../services/api';
import ReactDOM from 'react-dom';
import { TextField, Button, InputLabel, FormLabel, Select, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import './styles.css';

import { connect } from 'react-redux';

const styles = {
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function AddBasedSurvey({user}) {

    const history = useHistory();

    const location = useLocation();

    const [formError, setFormError] = useState('')

    const [survey, setSurvey] = useState([]);

    const [selectSurvey, setSelectSurvey] = useState('');

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
       setCreationDate(convertToDate(new Date()));
       const param = {
            userid : user[0].userid,    
            grouproleid : user[0].grouproleid,    
            hospitalunitid : user[0].hospitalunitid,    
            questionnaireID: location.state.questionnaireID,
            description: selectSurvey,
            moduleStatusID: "2", // New
            lastModification: convertToDate(new Date()),
            creationDate: convertToDate(new Date())
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
            history.goBack();
       }
    }

    useEffect(() => {
       async function getSurvey(){
           const response = await api.get('/survey').catch( function (error) {
                console.log(error)
                if(error.response.data.Message) {
                    setError(error.response.data.Message);
                } else {
                    setError(error.response.data.msgRetorno);
                }
            });

           if(response) {
                setSurvey(response.data);
                console.log("Survey description", survey);
            }
        }
        getSurvey();
    }, [])

    function handleChange(e) {
        setError('');
        //console.log(user)
        //this.setState({ defaultModule: e.target.value});
        setSelectSurvey(e.target.value);
        console.log("Valor selecionado", selectSurvey);
    }

    function handleBackButton(){
        history.goBack();
    }

    {
        selectSurvey === '' && setSelectSurvey("WHO COVID-19 Rapid Version CRF")
    }

    return (
            <main className="container" id="#topo">
                <div className="mainNav">
                    <h2>Adicionar pesquisa derivada</h2>
                    <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                    <HashLink to='/add-based-survey#topo'>
                         <ArrowUpwardIcon className="ArrowUp" />
                    </HashLink>
                </div>
                <form className="module" onSubmit={handleSubmit}>
                    <div className="formGroup formGroup1">
                        <InputLabel>Selecione a Pesquisa:</InputLabel><br/>
                        <select name="selectSurvey" className="sel1" value={selectSurvey} onChange={handleChange}>
                           {
                                survey.map(q => ( 
                                        <option key={q.questionnaireID} value={q.description}>{q.description}</option>
                                 ))
                             }
                        </select>
                    </div>
                    <div className="formGroup formGroup2">
                        <InputLabel>Selecione o tipo de derivação:</InputLabel><br/>
                        <select name="selectSurvey" className="sel1" value={selectSurvey} onChange={handleChange}>
                           <option value="version">Nova Versão</option>
                           <option value="based">Como template</option>
                        </select>
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
            </main>
    );
}

export default connect(state => ({ user: state.user }))(AddBasedSurvey);