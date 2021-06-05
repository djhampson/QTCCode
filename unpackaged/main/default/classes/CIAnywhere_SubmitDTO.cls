/**
 * Created by armievergara on 21/8/18.
 */

public with sharing class CIAnywhere_SubmitDTO {
    public class Request{
        public String ProcessType;
        public String ProcessName;
        public RuntimeParametersWrapper RuntimeParameters;
        public List<PresetVariableValuesWrapper> PresetVariableValues;
        public Request(){
            this.ProcessType = '';
            this.ProcessName = '';
            this.RuntimeParameters = new RuntimeParametersWrapper();
            this.PresetVariableValues = new List<PresetVariableValuesWrapper>();
        }
    }

    public class Response{
        public String ProcessType;
        public String ProcessName;
        public String DpJobId;

        public Response() {
            this.ProcessType = '';
            this.ProcessName = '';
            this.DpJobId = '';
        }
    }

    public class PresetVariableValuesWrapper{
        public String VariableName;
        public String VariableValue;
        public PresetVariableValuesWrapper(string varName, string varValue){
            this.VariableName = varName;
            this.VariableValue = varValue;
        }
    }
    public class RuntimeParametersWrapper{
    }



}