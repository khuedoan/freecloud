package main

import (
	"context"
	"fmt"
	"os"

	"github.com/xanzy/go-gitlab"
	"k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

func setupGitLabRunner(kubeClient *kubernetes.Clientset) {
	runnerSecretName := "gitlab-runner-secret"
	runnerSecretNamespace := "gitlab"

	_, err := kubeClient.CoreV1().Secrets(runnerSecretNamespace).Get(context.TODO(), runnerSecretName, metav1.GetOptions{})
	if errors.IsNotFound(err) {
		fmt.Printf("Secret %s in namespace %s not found, registering new GitLab runner", runnerSecretName, runnerSecretNamespace)
	} else {
		fmt.Printf("Secret %s in namespace %s already exists, nothing to do", runnerSecretName, runnerSecretNamespace)
		return
	}

	gitlab_root_password := os.Getenv("gitlab_root_password")
	if gitlab_root_password == "" {
		panic("No GitLab root password provided")
	}

	// TOOD auto url
	gitlabClient, err := gitlab.NewBasicAuthClient(
		"root",
		gitlab_root_password,
		gitlab.WithBaseURL("http://gitlab.127-0-0-1.nip.io"),
	)
	if err != nil {
		panic(err.Error())
	}

	runner, _, err := gitlabClient.Users.CreateUserRunner(&gitlab.CreateUserRunnerOptions{
		RunnerType:  gitlab.Ptr("instance_type"),
		RunUntagged: gitlab.Ptr(true),
	})

	if err != nil {
		panic(err.Error())
	}

	runnerSecret := &v1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name: "gitlab-runner-secret",
		},
		Type: v1.SecretTypeOpaque,
		StringData: map[string]string{
			"runner-registration-token": "", // need to leave as an empty string for compatibility reasons
			"runner-token":              runner.Token,
		},
	}

	_, err = kubeClient.CoreV1().Secrets("gitlab").Create(context.TODO(), runnerSecret, metav1.CreateOptions{})
	if err != nil {
		panic(err.Error())
	}
}
