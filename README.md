# AWS and Google Cloud VPN Boilerplate
AWSとGoogle Cloud間でVPN接続を設定するボイラープレート

# ディレクトリ構成

```
.
├── .tool-versions
├── README.md
└── terraform/
    ├── aws/
    │   └── network/
    │       └── env/
    │           └── sample/
    ├── google_cloud/
    │   ├── network/
    │   │   └── env/
    │   │       └── sample/
    │   └── secrets/
    │       └──  env/
    │           └── sample/
    └── cross_cloud/
        └── env/
            └── sample/
```

- terraform
  - aws/
  
    AWS関連のリソース定義を保存するディレクトリ
    このボイラープレートではVPN接続先となるVPCのみを定義している。
  
    - network/
  
      VPC定義を管理する保存するディレクトリ
      
      - env/
  
         Terraformで利用するbackend configや、var fileを保存するディレクトリ
  
        - sample/
  
          var fileのサンプル
      
  - google_cloud/
  
    Google Cloud関連のリソース定義を保存するディレクトリ
    このボイラープレートではVPN接続先となるVPCとVPNで利用するSecret Managerを定義している。
  
    - network/
  
      VPC定義を管理する保存するディレクトリ
      
      - env/
  
         Terraformで利用するbackend configや、var fileを保存するディレクトリ
  
        - sample/
  
          var fileのサンプル
  
    - secrets/
  
      Secret定義を管理する保存するディレクトリ
      
      - env/
  
         Terraformで利用するbackend configや、var fileを保存するディレクトリ
  
        - sample/
  
          var fileのサンプル
  
  - cross_cloud/
  
    AWSとGoogle Cloud間のVPN設定を行なうリソース定義を保存するディレクトリ
    
  
      - env/
  
         Terraformで利用するbackend configや、var fileを保存するディレクトリ
  
        - sample/
  
          var fileのサンプル


## ディレクトリ間の依存関係

``` mermaid
flowchart BT
  subgraph aws/
  aws_network[network/]
  end

  subgraph google_cloud/
  google_network[network/]
  google_secrets[secrets/]
  end

  subgraph cross_cloud/
  cross_cloud[crosscloud/]
  aws_network    --> cross_cloud[cross_cloud/]
  google_network --> cross_cloud[cross_cloud/]
  google_secrets --> cross_cloud[cross_cloud/]
  end

```


# セットアップ
このサンプルでは[mise](https://github.com/jdx/mise)([asdf](https://github.com/asdf-vm/asdf))を利用してツールのインストールを行なっている。

## miseをインストールする
``` bash
curl https://mise.run | sh
~/.local/bin/mise --version
export PATH=~$HOME/.local/bin/$PATH
```

## miseをアクティベートする
``` bash
eval "$(~/.local/bin/mise activate bash)"
```

## cliツールをインストールする。

```bash
mise plugin install terraform awscli gcloud terraform-docs
mise install
```

