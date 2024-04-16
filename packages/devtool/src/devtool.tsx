import classnames from 'classnames';
import { omit } from 'lodash-es';

import CodalioLogo from './CodalioImage.png';
import styles from './CodalioDevTool.module.css';
import { useLocalStorage } from 'react-use';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { useMutation, useQuery } from '@tanstack/react-query';
import { Button, Input } from 'reactstrap';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { networkApiCallOnlyData } from '@rhino-project/core/lib';
import { createConsumer } from '@rails/actioncable';
import env from '@rhino-project/config/env';

const queryClient = new QueryClient({});

const useDevAi = () => {
  // @ts-expect-error - Too complex to type
  const mutationFn = useCallback((data) => {
    const endpoint = '/api/dev/ai';

    // @ts-expect-error - Too complex to type
    return networkApiCallOnlyData(endpoint, {
      method: 'post',
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      data
    });
  }, []);

  const mutation = useMutation({
    mutationFn
  });

  return mutation;
};

const useDevAiEnabled = (): boolean => {
  const queryFn = useCallback(() => {
    const endpoint = '/api/dev/ai';

    return networkApiCallOnlyData(endpoint);
  }, []);

  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  const { data } = useQuery({
    queryFn,
    queryKey: ['dev-ai-enabled']
  });

  // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-member-access
  return data?.enabled || false;
};

export const RHINO_DEV_BROADCAST_CHANNEL = 'rhino_dev_channel';

const CodalioDevToolAI = () => {
  const [content, setContent] = useState('');
  const { mutate, isLoading } = useDevAi();
  const aiEnabled = useDevAiEnabled();
  const [contexts, setContexts] = useState({});

  console.log(env);
  const consumer = useMemo(
    () =>
      createConsumer(
        `${env.CODALIO_ENDPOINT}/cable?api_key=${env.CODALIO_API_KEY}`
      ),
    []
  );

  useEffect(() => {
    consumer.subscriptions.create(
      { channel: 'AiChannel' },
      {
        connected() {},
        received(data) {
          console.log(data);
        }
      }
    );
  }, [consumer]);

  useEffect(() => {
    const bc = new BroadcastChannel(RHINO_DEV_BROADCAST_CHANNEL);

    bc.onmessage = ({ data }) => {
      const { id, action } = data;

      setContexts((current) => {
        if (action === 'remove') return omit(current, [id]);

        return {
          ...current,
          [id]: data
        };
      });
    };

    // Close on unmount
    return () => bc.close();
  }, []);

  const handleClick = useCallback(() => {
    mutate({ content, contexts });
  }, [mutate, content, contexts]);

  if (!aiEnabled) {
    return <div>AI is disabled</div>;
  }

  return (
    <div className="d-flex flex-column">
      <Input
        type="textarea"
        disabled={isLoading}
        value={content}
        onChange={({ target: { value } }) => setContent(value)}
      />

      <Button disabled={isLoading} loading={isLoading} onClick={handleClick}>
        AI
      </Button>
    </div>
  );
};

export const CodalioDevtool = () => {
  const [isCollapsed, setIsCollapsed] = useLocalStorage('codalioDevtool', true);

  const toggleCollapse = () => setIsCollapsed(!isCollapsed);

  return (
    <QueryClientProvider client={queryClient}>
      {isCollapsed && (
        <button onClick={toggleCollapse} className={styles.toggleButton}>
          <img src={CodalioLogo} alt="Toggle" width="40" height="40" />
        </button>
      )}
      <div
        className={classnames(styles.rhinoTool, {
          // @ts-expect-error - Too complex to type
          [styles.collapsed]: isCollapsed
        })}
      >
        {!isCollapsed && (
          <div className={styles.content}>
            <div className="d-flex flex-row justify-content-between">
              <h5>Codalio</h5>
              <Button close onClick={toggleCollapse} />
            </div>
            <CodalioDevToolAI />
          </div>
        )}
      </div>
    </QueryClientProvider>
  );
};
