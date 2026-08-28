# AWS SSO login + set AWS_PROFILE + point kubectl at the account's EKS cluster

function awsso --description "AWS SSO login, set AWS_PROFILE, configure kubectl for EKS"
    set -l profile $argv[1]
    set -l region $argv[2]
    if test -z "$profile"
        if not set -q AWS_PROFILE[1]
            echo "AWS_PROFILE is not set. Set it in the project's .envrc or pass a profile to awsso."
            return 1
        end
        set profile "$AWS_PROFILE"
    end
    test -z "$region"; and set region us-east-1

    set -gx AWS_PROFILE "$profile"
    if not aws sts get-caller-identity --profile="$profile" >/dev/null 2>&1
        aws sso login --profile="$profile"; or return
    end

    set -l cluster (aws eks list-clusters --region "$region" --query 'clusters[0]' --output text 2>/dev/null)
    if test -n "$cluster"; and test "$cluster" != None
        if aws eks update-kubeconfig --region "$region" --name "$cluster" --profile "$profile" >/dev/null
            echo "kubectl context: "(kubectl config current-context)
        end
    end
end

# AWS SSO logout + clear AWS_PROFILE in current shell
function awssout --description "AWS SSO logout and clear AWS_PROFILE"
    aws sso logout
    set -e AWS_PROFILE
end
