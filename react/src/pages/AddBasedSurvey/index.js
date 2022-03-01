import React, { useState, useEffect, useRef } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import api from '../../services/api';
import ReactDOM from 'react-dom';
import { Button, InputLabel, CircularProgress, TextField } from '@material-ui/core';
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
    const refSurvey = useRef("1"); 
    const refMethod = useRef("version");
    const refIsNewVersionOf = useRef("1");
    const refIsBasedOn = useLocation("0");
    const [formError, setFormError] = useState('')
    const [survey, setSurvey] = useState([]);
    const [surveyDesc, setSurveyDesc] = useState('');
    const [selectSurvey, setSelectSurvey] = useState('');
    const [selectMethod, setSelectMethod] = useState('');
    const [isNewVersionOf, setIsNewVersionOf] = useState('');
    const [isBasedOn, setIsBasedOn] = useState('');
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
            isnewversionof: isNewVersionOf,
            isbasedon: isBasedOn,
            description: surveyDesc,
            version: "0.0",
            questionnaireStatusID: "2", // New
            lastModification: creationDate,
            creationDate: creationDate
        }
        console.log("request", param);
        console.log("SelectedSurvey", selectSurvey);
        console.log("SelectedMethod", selectMethod);
        console.log("IsNewVersionOf", isNewVersionOf);
        console.log("IsBasedOn", isBasedOn);
        console.log("======================");
        const response = await api.post('survey/', param).catch( function (error) {
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
            history.push("survey/");
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
        //console.log(user);
        setSelectSurvey(e.target.value);
        refSurvey.current = e.target.value;
        setIsNewVersionOf('0');  
        setIsBasedOn('0');
        refIsNewVersionOf.current = 0;
        refIsBasedOn.current = 0;
        refMethod.current === "Nova versão" ? refIsNewVersionOf.current = refSurvey && setIsNewVersionOf(refSurvey.current) : refIsBasedOn.current = refSurvey && setIsBasedOn(refSurvey.current) ;
        console.log("Valor selecionado", selectSurvey);
        setCreationDate(convertToDate(new Date()));
        console.log("SelectSurvey", refSurvey);
        console.log("SelectMethod", refMethod.current);
        console.log("IsNewVersionOf", isNewVersionOf);
        console.log("IsBasedOn", isBasedOn);
        console.log("======================");
    }


    function handleChange1(e) {
        setError('');
        refMethod.current = e.target.value;
        setSelectMethod(refMethod.current);
        setCreationDate(convertToDate(new Date()));
        setIsNewVersionOf('0');  
        setIsBasedOn('0');
        refIsNewVersionOf.current = 0;
        refIsBasedOn.current = 0;
        refMethod.current === "Nova versão" ? refIsNewVersionOf.current = refSurvey && setIsNewVersionOf(refSurvey.current) : refIsBasedOn.current = refSurvey && setIsBasedOn(refSurvey.current) ;
        console.log("SelectSurvey", refSurvey);
        console.log("SelectMethod", refMethod.current);
        console.log("IsNewVersionOf", isNewVersionOf);
        console.log("IsBasedOn", isBasedOn);
        console.log("======================");
    }

    useEffect(() => {
       
    }, [])    

    function handleChange2(e) {
        setError('');
        //console.log(user)
        //console.log("Location pesq", location)
        setSurveyDesc(e.target.value)
        //console.log(survey);
    }

    function handleBackButton(){
        history.goBack();
    }

    {
        selectSurvey === '' && setSelectSurvey(1);
        selectMethod === '' && setSelectMethod("Nova versão");
        isNewVersionOf === '' && setIsNewVersionOf("1") && setIsBasedOn("0");
        isBasedOn === '' && setIsBasedOn("0");
        creationDate == '' &&  setCreationDate(convertToDate(new Date()));
        
    }

    return (
            <main className="container" id="#topo">
                <div className="mainNav">
                    <h2>Adicionar pesquisa derivada</h2>
                    <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                    <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
                </div>
                <form className="module" onSubmit={handleSubmit}>
                    <div className="formGroup formGroup1">
                        <InputLabel>Selecione a Pesquisa:</InputLabel><br/>
                        <select name="selectSurvey" className="sel1" value={selectSurvey} onChange={handleChange}>
                           {
                                survey.map(q => ( 
                                        <option key={q.questionnaireID} value={q.questionnaireID}>{q.description}</option>
                                 ))
                             }
                        </select>
                    </div>
                    <div className="formGroup formGroup2">
                        <InputLabel>Selecione o tipo de derivação:</InputLabel><br/>
                        <select name="selectMethod" className="sel1" value={selectMethod} onChange={handleChange1}>
                           <option key="1" value="Nova versão">Nova Versão</option>
                           <option key="2" value="Como template">Como template</option>
                        </select>
                    </div>
                    <div className="formGroup formGroup2">
                        <InputLabel>Digite a descrição para sua pesquisa (pt-br): (versão: 0.0) </InputLabel><br/>
                        <TextField className="inputDescription" name="survey" label="Descrição" onChange={handleChange2} value={surveyDesc} style={styles.TextField} />
                    </div>
                    <div className="submit-prontuario">
                        <span className="error">{ error }</span>
                        <span className="success">{ success }</span>
                        <br/>
                        <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!surveyDesc}>
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