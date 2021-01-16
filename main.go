package main

import (
	"fmt"

	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/apimachinery/pkg/selection"
	v1 "k8s.io/client-go/listers/apps/v1"
)

const functionLabel = "faas_function"

func main() {
	fmt.Println("Hello, welcome to the buildx bug")
}

func getServiceList(functionNamespace string, deploymentLister v1.DeploymentLister) ([]string, error) {
	functions := []string{}

	sel := labels.NewSelector()
	req, err := labels.NewRequirement(functionLabel, selection.Exists, []string{})
	if err != nil {
		return functions, err
	}
	onlyFunctions := sel.Add(*req)

	res, err := deploymentLister.Deployments(functionNamespace).List(onlyFunctions)
	if err != nil {
		return nil, err
	}

	for _, item := range res {
		if item != nil {
			functions = append(functions, item.Name)
		}
	}

	return functions, nil
}
